SetWorkingDir %A_ScriptDir%
FilePath := "answers.xml"

Gui, Add, TreeView, gChoice w375 h500 vTree Section
Gui, Add, Edit, gType ym w375 h500 vData
Gui, Add, Button, gCopy w370 Section xs, Copy XML
Gui, Add, Button, gNewOption w370, New Option
Gui, Add, Button, gDelOption w370 xs, Delete Selected
Gui, Add, Button, gSaveFile w180 Section, Save
Gui, Add, Button, gLoadFile w180 ys, Load
Gui, Add, Edit, vFilePath w330 ys, % FilePath
Gui, Add, Button, gBrowse w30 ys, ...

Gui, Show,, AutoHotkey Quick Help Editor

If not FileExist(FilePath)
	URLDownloadToFile, http://apps.aboutscript.com/ahkhelp/inc/answers.xml, answers.xml
FileRead, fileData, % FilePath
fileXml := loadXML(fileData)
textData := Tree(fileXml.childNodes)
fileXml := ""
return

GuiClose:
ExitApp

SaveFile:
GuiControlGet, FilePath
if StrLen(FilePath) < 5
	return
if FileExist(FilePath)
{
	FileRead, OldData, % FilePath
	FileDelete, % FilePath
	FileAppend, % OldData, % FilePath ".bak"
}
FileAppend, % TreeParse(TV_GetNext()), % FilePath
return

LoadFile:
GuiControlGet, FilePath
if StrLen(FilePath) < 5
	return
FileRead, fileData, % FilePath
if fileData
{
	fileXml := loadXML(fileData)
	treeData := Tree(fileXml.childNodes)
	fileXml := ""	
}
return

Browse:
GuiControlGet, FilePath
FileSelectFile, NewFilePath, S2, % FilePath, Where would you like to save the XML file?, XML File (*.xml)
If not InStr(NewPath, ".xml")
	NewPath .= ".xml"
GuiControl,, FilePath, % NewFilePath
return

NewOption:
AddBranch(TV_GetSelection())
return

DelOption:
Selected := TV_GetSelection()
TV_GetText(tag, selected)
if tag = OPTION
	TV_Delete(Selected)
return

AddBranch(id) {
	global textData
	TV_GetText(tag, id)
	OutputDebug, % tag
	if tag not in OPTION,HELP
		return
	
	newOpt := TV_Add("option", id, "Expand")
	
	nameId := TV_Add("name", newOpt, "Expand")
		nameDataId := TV_Add("@cdata-section", nameId, "Expand")
	dataId := TV_Add("data", newOpt, "Expand")
		dataDataId := TV_Add("@cdata-section", dataId, "Expand")
	
	textData[nameDataId] := ""
	textData[dataDataId] := ""
}

Choice:
if A_GuiEvent != S
	return
Selected := A_EventInfo
OutputDebug % Selected
if textData.HasKey(Selected)
	GuiControl,, Data, % textData[Selected]
return

Type:
SetTimer, Update, -500
LastSelected := Selected
return

Update:
If (LastSelected = Selected)
{
	GuiControlGet, Data
	textData[Selected] := Data
}
SetTimer, Update, Off
return

Copy:
Clipboard := TreeParse(TV_GetNext()) ; Start with HELP
return

Tree(Xml, parent=0, textCount=0) {
	global XmlItem, XmlList
	
	if not parent
	{
		;~ GuiControl, -Redraw, Tree
		TV_Delete() ; Clear everything
	}
	
	out := {}
	for node in Xml
	{
		Name := node.nodeName
		;~ OutputDebug, nodeName: %Name%
		
		if (Name = "#text" || Name = "#cdata-section")
		{
			; Limit to 70 characters of data
			Data := node.nodeValue
			;~ Data := StrLen(Data) > 70 ? SubStr(Data, 1, 67) "..." : Data
			;~ id := TV_Add(Data, parent, "Expand")
			;~ Item := new XmlItem(id, node.nodeName, node.nodeValue)
			;~ OutputDebug % item.id
			;~ List.Add(Item.id, Item)
			outKey := "@" SubStr(Name, 2) "-" (++textCount) ; e.g., @text3
			id := TV_Add(outKey, parent, "Expand")
			out[id] := node.nodeValue
		}
		else if node.hasChildNodes
		{
			id := TV_Add(node.nodeName, parent, "Expand")
			last_out := Tree(node.childNodes, id, textCount)
			for k, v in last_out
				out[k] := v
			;~ Item := new XmlItem(id, node.nodeName, node.nodeValue)
			;~ List.Add(Item.id, Item)
		}
	}
	
	;~ GuiControl, +Redraw, Tree
	return out
}

TreeParse(id, depth=0) {
	global textData
	TV_GetText(tag, id)	
	str := ""
	
	if not depth
		str .= "<?xml version=""1.0"" encoding=""utf-8""?>"
	
	str .= "`n"
	indent(str, depth)		
	
	if (InStr(tag, "@") = 1 && textData.HasKey(id))
	{ ; It's plain text
		str := "<![CDATA[" textData[id] "]]>"
	}
	else
	{ 
		str .= "<" tag ">"
		
		if (child := TV_GetChild(id)) {
			str .= TreeParse(child, depth+1)
		}
				
		str .= "`n"
		indent(str, depth)
		str .= "</" tag ">"
		
		; Data needs an option following it.  If there isn't one, put a 
		; self closing option
		/*if (tag = "DATA") && (TV_GetNext(id) = 0)
		{
			str .= "`n"
			indent(str, depth)
			str .= "<option> </option>"
		}
		*/
	}
	
	sib := id
	while (!TV_GetPrev(id)) && (sib := TV_GetNext(sib))
		str .= TreeParse(sib, depth)
	
	return str
}

indent(byref str, depth) {
	loop % depth
		str .= "  " ; two spaces
}

loadXML(ByRef data)
{
   o := ComObjCreate("MSXML2.DOMDocument.6.0")
   o.async := false
   o.loadXML(data)
   return o
}
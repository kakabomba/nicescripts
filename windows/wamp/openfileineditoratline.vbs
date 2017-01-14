Editor = """C:\Program Files\NetBeans 7.4\bin\netbeans.exe"" --open "
EditorTitlePattern = "NetBeans IDE"
MakaronyHttdocs = "Z:\"
LocalHttdocs = "C:\wamp\www\"
MakaronyDomain = "z.ntaxa.com"
LocalDomain = "b"

Set Rules = CreateObject("Scripting.Dictionary")
Rules.Add "^netbeans:\/\/(" & Replace(LocalHttdocs,"\","\\") & ".*)$", 			Editor & "$1"
Rules.Add "^netbeans:\/\/[\.\/\w\d-]*\/ntaxa\/z\/(.*)$", 							Editor & MakaronyHttdocs & "$1"
Rules.Add "^netbeans:.*fbtmp([^\\]*)\\(.*)\." & LocalDomain & "\\(.*)$", 		Editor & LocalHttdocs & "$2\$3"
Rules.Add "^netbeans:.*fbtmp([^\\]*)\\(.*)\." & MakaronyDomain & "\\(.*)$",		Editor & MakaronyHttdocs & "$2\$3"

FileString = Wscript.Arguments(0)
'WScript.Echo FileString

Sub EditorToFront() 
	Set Word = CreateObject("Word.Application")
	Set Tasks = Word.Tasks
	Set NameRegex = CreateObject("VBScript.RegExp")
	NameRegex.Pattern = EditorTitlePattern

	For Each Task in Tasks
		If NameRegex.Test(Task.name) Then
		objShell.AppActivate(Task.name)
    End If
	Next
End Sub

Match = Rules.Keys  ' Field names  '
Repl = Rules.Items ' Field values '
For c = 0 To Rules.Count - 1
    'WScript.Echo Match(c) & "->" & Repl(c)
	
	Set Regex = CreateObject("VBScript.RegExp")
	Regex.Pattern = Match(c)
	If Regex.Test(FileString) Then
		RunCommand = Regex.Replace(FileString, Repl(c))
		'WScript.Echo RunCommand
		
		'following lines replace linux slash to windows backslash
		Set RegexLinux2WindowsSlash = CreateObject("VBScript.RegExp")
		RegexLinux2WindowsSlash.Pattern = "\/"
		RegexLinux2WindowsSlash.Global = True
		RunCommand = RegexLinux2WindowsSlash.Replace(RunCommand, "\\")
		'WScript.Echo RunCommand
		
		Set objShell = wscript.createobject("wscript.shell")
		EditorToFront()
		pid = objShell.Run(RunCommand,8,true)
		EditorToFront()
		End If
Next

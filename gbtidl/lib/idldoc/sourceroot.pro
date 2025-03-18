; From Jim Pendelton, Oct. 2001
Function SourceRoot
Help, Calls = Calls
UpperRoutine = (StrTok(Calls[1], ' ', /Extract))[0]
Skip = 0
Catch, ErrorNumber
If (ErrorNumber ne 0) then Begin
    Catch, /Cancel
    ThisRoutine = Routine_Info(UpperRoutine, /Functions, /Source)
    Skip = 1
EndIf
If (Skip eq 0) then Begin
    ThisRoutine = Routine_Info(UpperRoutine, /Source)
EndIf
Case StrUpCase(!version.os_family) of
    'WINDOWS' : DirSep = '\'
    'UNIX' : DirSep = '/'
    'MACOS' : DirSep = ':'
    'VMS' : DirSep = ']'
    Else : DirSep = ''
EndCase
Root = StrMid(ThisRoutine.Path, 0, StrPos(ThisRoutine.Path, DirSep, /Reverse_Search) + 1)
Return, Root
End

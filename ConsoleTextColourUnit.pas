Unit ConsoleTextColourUnit;

Interface
  Uses Winapi.Windows;
  Procedure SetC (Colour : DWord);
  Procedure ResetC;

Implementation

Procedure SetC(Colour : DWord);
  Begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), Colour);
  End;

Procedure ResetC;
  Begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  End;
End.

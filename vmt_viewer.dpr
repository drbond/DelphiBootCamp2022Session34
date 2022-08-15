Program vmt_viewer;

Uses
  FastMM4,
  Forms,
  vmtview in '..\ClassCreationExperimental\vmtview.pas' {ClassViewer},
  newClass in '..\ClassCreationExperimental\newClass.pas',
  vmtStructure in '..\ClassCreationExperimental\vmtStructure.pas',
  vmtBuilder in '..\ClassCreationExperimental\vmtBuilder.pas';

{$R *.res}

Begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TClassViewer, ClassViewer);
  Application.Run;
End.

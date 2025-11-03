program DelphiMultithreadingBook0308;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0308.MainForm in 'DelphiMultithreadingBook0308.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0308.Worker in 'DelphiMultithreadingBook0308.Worker.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

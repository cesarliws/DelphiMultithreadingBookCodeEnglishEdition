program DelphiMultithreadingBook0405;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0405.MainForm in 'DelphiMultithreadingBook0405.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0405.WorkerWithErrorThread in 'DelphiMultithreadingBook0405.WorkerWithErrorThread.pas',
  DelphiMultithreadingBook0405.WorkerWithExceptionThread in 'DelphiMultithreadingBook0405.WorkerWithExceptionThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

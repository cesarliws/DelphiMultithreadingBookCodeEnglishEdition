program DelphiMultithreadingBook0406;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0406.MainForm in 'DelphiMultithreadingBook0406.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0406.WorkerWithRetryOnErrorThread in 'DelphiMultithreadingBook0406.WorkerWithRetryOnErrorThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook.ExceptionUtils in '..\Common\DelphiMultithreadingBook.ExceptionUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

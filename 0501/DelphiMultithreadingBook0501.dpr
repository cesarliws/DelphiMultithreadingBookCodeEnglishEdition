program DelphiMultithreadingBook0501;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0501.MainForm in 'DelphiMultithreadingBook0501.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0501.MessageWorkerThread in 'DelphiMultithreadingBook0501.MessageWorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

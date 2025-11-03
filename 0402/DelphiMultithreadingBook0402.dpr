program DelphiMultithreadingBook0402;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0402.MainForm in 'DelphiMultithreadingBook0402.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0402.WorkerThread in 'DelphiMultithreadingBook0402.WorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

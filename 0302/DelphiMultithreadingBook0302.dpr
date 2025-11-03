program DelphiMultithreadingBook0302;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0302.MainForm in 'DelphiMultithreadingBook0302.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0302.SharedData in 'DelphiMultithreadingBook0302.SharedData.pas',
  DelphiMultithreadingBook0302.WorkerThread in 'DelphiMultithreadingBook0302.WorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

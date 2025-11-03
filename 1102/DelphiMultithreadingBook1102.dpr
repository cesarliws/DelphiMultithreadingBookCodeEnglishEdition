program DelphiMultithreadingBook1102;

uses
  Vcl.Forms,
  DelphiMultithreadingBook1102.MainForm in 'DelphiMultithreadingBook1102.MainForm.pas' {MainForm},
  DelphiMultithreadingBook1102.DBWorkerThread in 'DelphiMultithreadingBook1102.DBWorkerThread.pas',
  DelphiMultithreadingBook1102.WorkerDataModule in 'DelphiMultithreadingBook1102.WorkerDataModule.pas' {WorkerDM: TDataModule},
  DelphiMultithreadingBook.CancellationToken in '..\Common\DelphiMultithreadingBook.CancellationToken.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TWorkerDM, WorkerDM);
  Application.Run;
end.

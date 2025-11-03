program DelphiMultithreadingBook0203;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0203.SharedData in 'DelphiMultithreadingBook0203.SharedData.pas',
  DelphiMultithreadingBook0203.WorkerThread in 'DelphiMultithreadingBook0203.WorkerThread.pas',
  DelphiMultithreadingBook0203.MainForm in 'DelphiMultithreadingBook0203.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

program DelphiMultithreadingBook0301;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0301.MainForm in 'DelphiMultithreadingBook0301.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0301.SharedData in 'DelphiMultithreadingBook0301.SharedData.pas',
  DelphiMultithreadingBook0301.WorkerThread in 'DelphiMultithreadingBook0301.WorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

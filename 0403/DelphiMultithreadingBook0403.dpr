program DelphiMultithreadingBook0403;

uses
  Vcl.Forms,
  DelphiMultithreadingBook.CancellationToken in '..\Common\DelphiMultithreadingBook.CancellationToken.pas',
  DelphiMultithreadingBook0403.MainForm in 'DelphiMultithreadingBook0403.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0403.PausableWorkerThread in 'DelphiMultithreadingBook0403.PausableWorkerThread.pas',
  DelphiMultithreadingBook0403.SharedData in 'DelphiMultithreadingBook0403.SharedData.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

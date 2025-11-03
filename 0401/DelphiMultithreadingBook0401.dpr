program DelphiMultithreadingBook0401;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0401.MainForm in 'DelphiMultithreadingBook0401.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0401.SharedData in 'DelphiMultithreadingBook0401.SharedData.pas',
  DelphiMultithreadingBook0401.PausableWorkerThread in 'DelphiMultithreadingBook0401.PausableWorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

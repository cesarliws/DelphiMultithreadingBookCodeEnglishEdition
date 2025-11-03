program DelphiMultithreadingBook0505;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0505.MainForm in 'DelphiMultithreadingBook0505.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0505.WorkerThread in 'DelphiMultithreadingBook0505.WorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

program DelphiMultithreadingBook0304;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0304.MainForm in 'DelphiMultithreadingBook0304.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0304.SharedData in 'DelphiMultithreadingBook0304.SharedData.pas',
  DelphiMultithreadingBook0304.WorkerThread in 'DelphiMultithreadingBook0304.WorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

program DelphiMultithreadingBook0705;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0705.MainForm in 'DelphiMultithreadingBook0705.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0705.SharedData in 'DelphiMultithreadingBook0705.SharedData.pas',
  DelphiMultithreadingBook0705.WorkerThreads in 'DelphiMultithreadingBook0705.WorkerThreads.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

program DelphiMultithreadingBook0801;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0801.MainForm in 'DelphiMultithreadingBook0801.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0801.WorkerProcessor in 'DelphiMultithreadingBook0801.WorkerProcessor.pas',
  DelphiMultithreadingBook0801.WorkerThread in 'DelphiMultithreadingBook0801.WorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

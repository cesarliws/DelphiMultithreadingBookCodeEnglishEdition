program DelphiMultithreadingBook0201;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0201.MainForm in 'DelphiMultithreadingBook0201.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0201.WorkerThread in 'DelphiMultithreadingBook0201.WorkerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

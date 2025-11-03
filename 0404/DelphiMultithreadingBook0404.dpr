program DelphiMultithreadingBook0404;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0404.MainForm in 'DelphiMultithreadingBook0404.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0404.PriorityWorker in 'DelphiMultithreadingBook0404.PriorityWorker.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

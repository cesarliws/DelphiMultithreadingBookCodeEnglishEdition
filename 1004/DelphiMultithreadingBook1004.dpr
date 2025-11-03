program DelphiMultithreadingBook1004;

uses
  Vcl.Forms,
  DelphiMultithreadingBook1004.MainForm in 'DelphiMultithreadingBook1004.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook1004.PipelineTasks in 'DelphiMultithreadingBook1004.PipelineTasks.pas',
  DelphiMultithreadingBook.CancellationToken in '..\Common\DelphiMultithreadingBook.CancellationToken.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

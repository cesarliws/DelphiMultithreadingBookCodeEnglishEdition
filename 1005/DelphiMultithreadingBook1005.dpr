program DelphiMultithreadingBook1005;

uses
  Vcl.Forms,
  DelphiMultithreadingBook1005.MainForm in 'DelphiMultithreadingBook1005.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook1005.PipelineProcessor in 'DelphiMultithreadingBook1005.PipelineProcessor.pas',
  DelphiMultithreadingBook.CancellationToken in '..\Common\DelphiMultithreadingBook.CancellationToken.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

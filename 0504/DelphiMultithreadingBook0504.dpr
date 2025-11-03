program DelphiMultithreadingBook0504;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0504.MainForm in 'DelphiMultithreadingBook0504.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0504.AsyncHelpers in 'DelphiMultithreadingBook0504.AsyncHelpers.pas',
  DelphiMultithreadingBook0504.MainThreadDispatcher in 'DelphiMultithreadingBook0504.MainThreadDispatcher.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

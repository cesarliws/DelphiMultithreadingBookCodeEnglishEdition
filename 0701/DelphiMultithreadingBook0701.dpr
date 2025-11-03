program DelphiMultithreadingBook0701;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0701.MainForm in 'DelphiMultithreadingBook0701.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0701.SimpleThreadPool in 'DelphiMultithreadingBook0701.SimpleThreadPool.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

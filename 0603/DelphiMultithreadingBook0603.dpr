program DelphiMultithreadingBook0603;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0603.MainForm in 'DelphiMultithreadingBook0603.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.CancellationToken in '..\Common\DelphiMultithreadingBook.CancellationToken.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

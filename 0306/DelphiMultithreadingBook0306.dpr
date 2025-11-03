program DelphiMultithreadingBook0306;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0306.MainForm in 'DelphiMultithreadingBook0306.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0306.Workers in 'DelphiMultithreadingBook0306.Workers.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

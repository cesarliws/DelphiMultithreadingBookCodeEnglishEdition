program DelphiMultithreadingBook0605;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0605.MainForm in 'DelphiMultithreadingBook0605.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

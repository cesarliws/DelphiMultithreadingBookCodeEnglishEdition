program DelphiMultithreadingBook0204;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0204.MainForm in 'DelphiMultithreadingBook0204.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

program DelphiMultithreadingBook0604;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0604.MainForm in 'DelphiMultithreadingBook0604.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

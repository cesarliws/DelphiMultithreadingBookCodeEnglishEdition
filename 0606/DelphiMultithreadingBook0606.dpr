program DelphiMultithreadingBook0606;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0606.MainForm in 'DelphiMultithreadingBook0606.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

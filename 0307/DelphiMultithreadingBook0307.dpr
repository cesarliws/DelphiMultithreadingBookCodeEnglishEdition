program DelphiMultithreadingBook0307;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0307.MainForm in 'DelphiMultithreadingBook0307.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

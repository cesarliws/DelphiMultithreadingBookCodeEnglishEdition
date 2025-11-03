program DelphiMultithreadingBook0303;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0303.MainForm in 'DelphiMultithreadingBook0303.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

program DelphiMultithreadingBook0704;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0704.MainForm in 'DelphiMultithreadingBook0704.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

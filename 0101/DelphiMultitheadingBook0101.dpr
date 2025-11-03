program DelphiMultitheadingBook0101;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0101.MainForm in 'DelphiMultithreadingBook0101.MainForm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

unit DelphiMultithreadingBook0101.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    StartSynchronousProcessingButton: TButton;
    LogMemo: TMemo;
    procedure StartSynchronousProcessingButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure LogWrite(const Text: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.DateUtils, System.SysUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LogWrite('Application started.');
end;

procedure TMainForm.StartSynchronousProcessingButtonClick(Sender: TObject);
var
  i: Integer;
  StartTime: TDateTime;
begin
  LogWrite('> Starting long-running operation.');
  LogWrite('Interface is NOT responsive, try moving the window...');
  // Ensures the message above is displayed
  Repaint;
  StartTime := Now;
  // A loop long enough to block
  for i := 0 to 10000000 do
  begin
    // Just to consume time. Sleep(0) yields the rest of the CPU quantum time,
    // but the main thread is still "busy."
    Sleep(0);
  end;
  LogWrite(Format('Long-running operation completed in %d ms!',
    [MilliSecondsBetween(Now, StartTime)]));
end;

procedure TMainForm.LogWrite(const Text: string);
begin
  LogMemo.Lines.Add(Text);
end;

end.
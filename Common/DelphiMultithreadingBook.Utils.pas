unit DelphiMultithreadingBook.Utils;

interface

uses
  System.Classes;

type
{$SCOPEDENUMS OFF}
  TRunningState = (IsRunning, IsPaused, IsStopped);
{$SCOPEDENUMS ON}

  /// <summary>
  ///   Defines the standard signature for log callbacks used in the examples.
  /// </summary>
  /// <remarks>
  ///   This type is centralized here in the utilities unit to ensure a
  ///   consistent pattern throughout the book. Worker threads will receive an
  ///   anonymous procedure or method with this signature to be able to
  ///   report messages back to the main thread in a safe and decoupled way.
  /// </remarks>
  TLogWriteCallback = reference to procedure(const text: string);

// LogWrite sends Text to the LogMemo
procedure LogWrite(const Text: string); overload;
procedure LogWrite(const Text: string; const Args: array of const); overload;

// DebugLogWrite sends Text to the Delphi Debug messages Window
procedure DebugLogWrite(const Text: string); overload;
procedure DebugLogWrite(const Text: string; const Args: array of const); overload;

// Register and Unregister the LogMemo.Lines that will receive the log messages
procedure RegisterLogger(const Logger: TStrings);
procedure UnregisterLogger;

// Helper function to identify the first PPL call and notify about the Warmup
function CheckTasksFirstRun(WriteLog: Boolean): Boolean;

// Simulate CPU processing
function SimulateCPUWork(Value: Integer = 0): Int64;

implementation

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows,
{$ENDIF}
  System.SysUtils;

var
  _logger: TStrings;
  _tasksFirstRun: Boolean;

procedure CheckMainThread;
begin
  if TThread.Current.ThreadID <> MainThreadID then
  begin
    raise Exception.Create('This method can only be called from the MainThread.');
  end;
end;

procedure RegisterLogger(const Logger: TStrings);
begin
  _logger := Logger;
end;

procedure UnregisterLogger;
begin
  _logger := nil;
end;

function CheckTasksFirstRun(WriteLog: Boolean): Boolean;
begin
  // TODO : add real check if the thread pool has been initialized
  if not _tasksFirstRun then
  begin
    _tasksFirstRun := True;
    if WriteLog then
    begin
      LogWrite('*** ATTENTION!');
      LogWrite('* First execution is slower due to Thread Pool initialization');
      LogWrite('* Run again for better performance');
    end;
    Result := False;
  end
  else
    Result := True;
end;

function SimulateCPUWork(Value: Integer = 0): Int64;
var
  i: Integer;
  Calc: Double;
begin
  if Value = 0 then
    Calc := Random(100)
  else
    Calc := Value;

  for i := 1 to 50 do
    Calc := Sin(Calc) + Sqrt(Abs(Calc));

  Result := Trunc(Calc);
end;

procedure LogWrite(const Text: string);
begin
  if not Assigned(_logger) then
    Exit;

  if TThread.Current.ThreadID = MainThreadID then
    _logger.Add(Text)
  else
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(_logger) then
          _logger.Add(Text);
      end);
end;

procedure LogWrite(const Text: string; const Args: array of const);
begin
   LogWrite(Format(Text, Args));
end;

procedure DebugLogWrite(const Text: string);
begin
  // The OutputDebugString function (from the WinApi.Windows unit) allows us
  // to send text messages to the "Events Window" of the Delphi IDE.
{$IFDEF MSWINDOWS}
  OutputDebugString(PChar(Text + sLineBreak));
{$ENDIF}
end;

procedure DebugLogWrite(const Text: string; const Args: array of const);
begin
  DebugLogWrite(Format(Text, Args));
end;

end.

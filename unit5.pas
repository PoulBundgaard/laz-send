unit Unit5;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TForm5 }

  TForm5 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form5: TForm5;

implementation
uses
   unit6;
{$R *.lfm}

{ TForm5 }

procedure TForm5.Button1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then memo1.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TForm5.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveFormState('implog',TForm(form5));
end;

procedure TForm5.FormShow(Sender: TObject);
begin
  LoadFormState('implog',TForm(form5));
end;

end.


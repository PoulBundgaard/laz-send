unit Unit7;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls;

type

  { TForm6 }

  TForm6 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    email : string;
  end;

var
  Form6: TForm6;

implementation

{$R *.lfm}

{ TForm6 }

procedure TForm6.Button1Click(Sender: TObject);
begin
  email:=label2.Caption;
  close;
end;

procedure TForm6.Button2Click(Sender: TObject);
begin
  email:=label3.Caption;
  close;
end;

procedure TForm6.Button3Click(Sender: TObject);
begin
  email:=label4.Caption;
  close;
end;

procedure TForm6.Button4Click(Sender: TObject);
begin
  email:='';
  close;
end;

end.


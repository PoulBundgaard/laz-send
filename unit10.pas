unit Unit10;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls;

type

  { TForm9 }

  TForm9 = class(TForm)
    Button1: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    ListBox1: TListBox;
    ListView1: TListView;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Process1: TProcess;
    Splitter1: TSplitter;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    default_id_operat : integer;
    default_nm_operat : string;

    acrobat_path : string;
  end;

var
  Form9: TForm9;

implementation
uses
  unit2;

{$R *.lfm}

{ TForm9 }

procedure TForm9.FormShow(Sender: TObject);
var
  sr              : TSearchRec;
  exe             : string;
  l               : TListItem;
  f               : TextFile;
  buf,buf2        : string;

  data,adres,temat: string;

begin
  ListView1.Clear;
  ListView1.BeginUpdate;
  ListBox1.Clear;

  exe:=ExtractFilePath(ParamStr(0));
  if exe[length(exe)] <> '\' then exe:=exe+'\';

  if FindFirst(exe+'wiadomosci\*nagl.txt',faAnyFile,sr) = 0 then
  begin
    repeat
      data:=copy(sr.Name,1,pos('#',sr.name));
      // wczytywanie adresatow i tematu
      AssignFile(f,exe+'wiadomosci\'+data+'adres.txt');
      reset(f);
      readln(f,adres);
      readln(f,temat);
      CloseFile(f);
      if trim(edit1.Text) <> '' then
      begin
        if (pos(UpperCase(edit1.Text),UpperCase(adres)) <> 0) or (pos(UpperCase(edit1.Text),UpperCase(temat)) <> 0) then
        begin
          l:=ListView1.Items.Add;
          l.Caption:=data;
          l.SubItems.Add(adres);
          l.SubItems.Add(temat);
        end;
      end
      else
      begin
        l:=ListView1.Items.Add;
        l.Caption:=data;
        l.SubItems.Add(adres);
        l.SubItems.Add(temat);
      end;

    until FindNext(sr) <> 0;
  end;
  ListView1.EndUpdate;
end;

// pokarz zalacznik
procedure TForm9.Button3Click(Sender: TObject);
var
  exe, buf : string;
begin
  if (ListView1.ItemIndex < 0) or (ListBox1.Items.Count = 0) or (ListBox1.ItemIndex < 0) then exit;
  exe:=ExtractFilePath(ParamStr(0));
  if exe[length(exe)] <> '\' then exe:=exe+'\';

  // budowanie nazwy pliku
  buf:=exe+'wiadomosci\'+ListView1.Items[ListView1.ItemIndex].Caption+'z#'+ListBox1.Items[ListBox1.ItemIndex];

  if process1.Active then process1.Terminate(0);
  if UpperCase(ExtractFileExt(buf)) = '.PDF' then process1.CommandLine:=acrobat_path+' "'+buf+'"'
  else
    process1.CommandLine:='explorer'+' "'+buf+'"';

  process1.Execute;
end;

// wyslij email ponownie
procedure TForm9.Button1Click(Sender: TObject);
var
  l : TListItem;
  i : integer;
  exe : string;
begin
  if ListView1.ItemIndex < 0 then exit;
  // sciezka do zalacznikow
  exe:=ExtractFilePath(ParamStr(0));
  if exe[length(exe)] <> '\' then exe:=exe+'\';
  exe:=exe+'wiadomosci\';

  form2.default_id_operat:=default_id_operat;
  form2.default_nm_operat:=default_nm_operat;
  form2.Edit1.Text:=ListView1.Items[ListView1.ItemIndex].SubItems[0]; // adresaci
  form2.Edit2.Text:='[C] '+ListView1.Items[ListView1.ItemIndex].SubItems[1]; // temat
  form2.SynEdit1.ClearAll;
  form2.SynEdit1.Lines.AddStrings(memo1.Lines);
  form2.ListView1.Clear;

  // zalaczniki
  for i:=0 to ListBox1.Count-1 do
  begin
    l:=form2.ListView1.Items.Add;

    l.caption:=ListView1.Items[ListView1.ItemIndex].Caption+'z#'+ListBox1.Items[i];
    l.SubItems.Add(exe);
  end;
  form2.bytes_sent:=0;
  form2.bytes_total:=0;
  form2.ProgressBar1.Position:=0;
  form2.StaticText1.Caption:='0.00%';
  form2.ShowModal;

  FormShow(nil);
end;

procedure TForm9.Edit1Change(Sender: TObject);
begin
  FormShow(nil);
end;

// klikniecie na liste email-i wsywietla zawartosc emaila i liste zalacznikow
procedure TForm9.ListView1Click(Sender: TObject);
var
  sr2         : TSearchRec;
  buf3,exe,buf: string;
begin
  if ListView1.ItemIndex < 0 then exit;
  ListBox1.Clear;

  exe:=ExtractFilePath(ParamStr(0));
  if exe[length(exe)] <> '\' then exe:=exe+'\';

  buf:=ListView1.Items[ListView1.ItemIndex].Caption;
  // wczytwanie tresci wiadomosci
  memo1.Lines.LoadFromFile(exe+'wiadomosci\'+buf+'nagl.txt');

  if FindFirst(exe+'wiadomosci\'+buf+'z#*.*',faAnyFile,sr2) = 0 then
  begin
    repeat
       buf3:=sr2.Name;
       while (buf3 <> '') and (buf3[1] <> '#') do delete(buf3,1,1);
       delete(buf3,1,3);
       ListBox1.Items.Add(buf3);
    until FindNext(sr2) <> 0;
  end;
end;

end.


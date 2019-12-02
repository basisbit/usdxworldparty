{*
    UltraStar Deluxe WorldParty - Karaoke Game

	UltraStar Deluxe WorldParty is the legal property of its developers,
	whose names	are too numerous to list here. Please refer to the
	COPYRIGHT file distributed with this source distribution.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. Check "LICENSE" file. If not, see
	<http://www.gnu.org/licenses/>.
 *}


unit UScreenOptionsLyrics;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  UMenu,
  sdl2,
  UDisplay,
  UMusic,
  UFiles,
  UIni,
  UThemes;

type
  TScreenOptionsLyrics = class(TMenu)
    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
  end;

implementation

uses
  UGraphic,
  UUnicodeUtils,
  SysUtils;

function TScreenOptionsLyrics.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenOptions);
        end;
      SDLK_RETURN:
        begin
          if SelInteraction = 3 then
          begin
            Ini.Save;
            AudioPlayback.PlaySound(SoundLib.Back);
            FadeTo(@ScreenOptions);
          end;
        end;
      SDLK_DOWN:
        InteractNext;
      SDLK_UP :
        InteractPrev;
      SDLK_RIGHT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 3) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractInc;
          end;
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 3) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;
        end;
    end;
  end;
end;

constructor TScreenOptionsLyrics.Create;
begin
  inherited Create;

  LoadFromTheme(Theme.OptionsLyrics);

  Theme.OptionsLyrics.SelectLyricsFont.showArrows := true;
  Theme.OptionsLyrics.SelectLyricsFont.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsLyrics.SelectLyricsFont, UIni.Ini.LyricsFont, UIni.ILyricsFont, 'OPTION_VALUE_');

  Theme.OptionsLyrics.SelectLyricsEffect.showArrows := true;
  Theme.OptionsLyrics.SelectLyricsEffect.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsLyrics.SelectLyricsEffect, UIni.Ini.LyricsEffect, UIni.ILyricsEffect, 'OPTION_VALUE_');

  Theme.OptionsLyrics.SelectNoteLines.showArrows := true;
  Theme.OptionsLyrics.SelectNoteLines.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsLyrics.SelectNoteLines, UIni.Ini.NoteLines, UIni.INoteLines, 'OPTION_VALUE_');

  AddButton(Theme.OptionsLyrics.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 5, Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);

end;

procedure TScreenOptionsLyrics.OnShow;
begin
  inherited;

  Interaction := 0;
end;

end.

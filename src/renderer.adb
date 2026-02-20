with Ada.Strings.Fixed;
with Ada.Strings;

package body Renderer is

   procedure Initialize_Colors is
   begin
      Start_Color;
      Init_Pair (Color_Pair (1), White, Black);   -- Stats / Default
      Init_Pair (Color_Pair (2), White, Black);   -- Player / Victory
      Init_Pair (Color_Pair (3), Yellow, Black);  -- Boulders
      Init_Pair (Color_Pair (4), White, Black);   -- Diamond
      Init_Pair (Color_Pair (5), Green, Black);   -- Exit
      Init_Pair (Color_Pair (6), Red, Black);     -- Game Over / Important
      Init_Pair (Color_Pair (7), Red, Black);     -- Walls
      Init_Pair (Color_Pair (8), Green, Black);   -- Dirt
   end Initialize_Colors;

   procedure Show_Splash_Screen is
      Win : constant Window := Standard_Window;
      L : Line_Count;
      C : Column_Count;
      Row : Line_Position;
   begin
      Get_Size (Win, L, C);
      Row := Line_Position (L) / 2 - 4;
      Erase (Win);
      
      Set_Character_Attributes (Win, Color => Color_Pair (6));
      Center_Text (Win, Row + 0, "  _____   ____   _____ _  ________ _____  ");
      Center_Text (Win, Row + 1, " |  __ \ / __ \ / ____| |/ /  ____|  __ \ ");
      Center_Text (Win, Row + 2, " | |__) | |  | | |    | ' /| |__  | |__) |");
      Center_Text (Win, Row + 3, " |  _  /| |  | | |    |  < |  __| |  _  / ");
      Center_Text (Win, Row + 4, " | | \ \| |__| | |____| . \| |____| | \ \ ");
      Center_Text (Win, Row + 5, " |_|  \_\\____/ \_____|_|\_\______|_|  \_\");
      
      Set_Character_Attributes (Win, Color => Color_Pair (1));
      Center_Text (Win, Row + 8, "A free implementation for Agat-7 heritage");
      Center_Text (Win, Row + 10, "Press any key to START");
      
      Refresh (Win);
   end Show_Splash_Screen;

   procedure Center_Text (Win : Window; Row : Line_Position; Text : String) is
      L : Line_Count;
      C : Column_Count;
   begin
      Get_Size (Win, L, C);
      declare
         Col : constant Column_Position := Column_Position ((Integer (C) - Text'Length) / 2);
      begin
         Move_Cursor (Win, Row, Col);
         Add (Win, Text);
      end;
   end Center_Text;

   procedure Draw_Game (State : Game_State) is
      Win : constant Window := Standard_Window;
      L : Line_Count;
      C : Column_Count;
      L_Off : Line_Position;
      C_Off : Column_Position;
      
      function Pad (Val : Integer; Width : Positive := 2) return String is
         S : constant String := Ada.Strings.Fixed.Trim (Val'Image, Ada.Strings.Both);
      begin
         if S'Length < Width then
            return [1 .. Width - S'Length => '0'] & S;
         else
            return S;
         end if;
      end Pad;

   begin
      Get_Size (Win, L, C);
      
      -- Total rows: 1 (stats) + 1 (gap) + Max_Rows = 24
      -- Total cols: Max_Cols = 80
      L_Off := Line_Position (Integer (L) - 24) / 2;
      C_Off := Column_Position (Integer (C) - 80) / 2;
      
      -- Safety check for small terminals
      if L_Off < 0 then L_Off := 0; end if;
      if C_Off < 0 then C_Off := 0; end if;

      Erase (Win);
      
      -- Stats (Line 0 relative to offset)
      Move_Cursor (Win, L_Off, C_Off);
      Add (Win, "Score: " & Pad (State.Score, 4) & "  Diamonds: " & 
           Pad (State.Diamonds_Held) & "/" & Pad (State.Diamonds_Needed) &
           "  Lives: " & Pad (State.Lives));
      
      -- Map (Line 2-23 relative to offset)
      for R in 1 .. Max_Rows loop
         for C_Idx in 1 .. Max_Cols loop
            Move_Cursor (Win, L_Off + Line_Position (R + 1), C_Off + Column_Position (C_Idx - 1));
            case State.Map (R, C_Idx) is
               when Player =>
                  Set_Character_Attributes (Win, Color => Color_Pair (2));
                  Add (Win, "P");
               when Boulder | Falling_Boulder =>
                  Set_Character_Attributes (Win, Color => Color_Pair (3));
                  Add (Win, "O");
               when Wall =>
                  Set_Character_Attributes (Win, Color => Color_Pair (7));
                  Add (Win, "#");
               when Diamond | Falling_Diamond =>
                  Set_Character_Attributes (Win, Color => Color_Pair (4));
                  Add (Win, "*");
               when Dirt =>
                  Set_Character_Attributes (Win, Color => Color_Pair (8));
                  Add (Win, "+");
               when Exit_Open =>
                  Set_Character_Attributes (Win, Attr => (Blink => True, others => False), Color => Color_Pair (5));
                  Add (Win, "E");
               when Space | Exit_Closed =>
                  Add (Win, " ");
            end case;
            Set_Character_Attributes (Win, Color => Color_Pair (1));
         end loop;
      end loop;
      
      Refresh (Win);
   end Draw_Game;

   procedure Show_Game_Over (State : Game_State) is
      Win : constant Window := Standard_Window;
      L : Line_Count;
      C : Column_Count;
      Row : Line_Position;
   begin
      Get_Size (Win, L, C);
      Row := Line_Position (L) / 2;
      Erase (Win);
      Set_Character_Attributes (Win, Color => Color_Pair (6));
      Center_Text (Win, Row - 1, "G A M E   O V E R");
      Set_Character_Attributes (Win, Color => Color_Pair (1));
      Center_Text (Win, Row + 1, "Your Final Score: " & State.Score'Image);
      Center_Text (Win, Row + 3, "Press 'R' to Restart or 'Q' to Quit");
      Refresh (Win);
   end Show_Game_Over;

   procedure Show_Level_Complete (State : Game_State) is
      Win : constant Window := Standard_Window;
      L : Line_Count;
      C : Column_Count;
      Row : Line_Position;
   begin
      Get_Size (Win, L, C);
      Row := Line_Position (L) / 2;
      Erase (Win);
      Set_Character_Attributes (Win, Color => Color_Pair (2));
      Center_Text (Win, Row - 1, "V I C T O R Y !");
      Set_Character_Attributes (Win, Color => Color_Pair (1));
      Center_Text (Win, Row + 1, "You escaped with " & State.Score'Image & " points!");
      Center_Text (Win, Row + 3, "Press 'R' to Play Again or 'Q' to Quit");
      Refresh (Win);
   end Show_Level_Complete;

end Renderer;

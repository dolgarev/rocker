with Ada.Numerics.Discrete_Random;

package body Levels is

   procedure Setup_Level (State : out Game_State; Level_Num : Integer) is
      pragma Unreferenced (Level_Num);
   begin
      Generate_Level (State);
   end Setup_Level;

   procedure Generate_Level (State : out Game_State) is
      subtype Rand_Range is Integer range 1 .. 100;
      package Random_Int is new Ada.Numerics.Discrete_Random (Rand_Range);
      G : Random_Int.Generator;
      Val : Rand_Range;
   begin
      -- First, reset/initialize state basics
      Initialize (State);
      
      Random_Int.Reset (G);
      
      for R in 1 .. Max_Rows loop
         for C in 1 .. Max_Cols loop
            if R = 1 or R = Max_Rows or C = 1 or C = Max_Cols then
               State.Map (R, C) := Wall;
            else
               Val := Random_Int.Random (G);
               if Val < 10 then
                  State.Map (R, C) := Boulder;
               elsif Val < 15 then
                  State.Map (R, C) := Diamond;
                  State.Diamonds_Needed := State.Diamonds_Needed + 1;
               elsif Val < 70 then
                  State.Map (R, C) := Dirt;
               else
                  State.Map (R, C) := Space;
               end if;
            end if;
         end loop;
      end loop;
      
      State.Player_Row := 2;
      State.Player_Col := 2;
      State.Map (State.Player_Row, State.Player_Col) := Player;
      
      -- Place Exit
      State.Map (Max_Rows - 1, Max_Cols - 1) := Exit_Closed;
   end Generate_Level;

end Levels;

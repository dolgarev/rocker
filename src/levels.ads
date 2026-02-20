with Engine; use Engine;

package Levels is

   procedure Setup_Level (State : out Game_State; Level_Num : Integer);
   
   -- Generate a solvable maze
   procedure Generate_Level (State : out Game_State);

end Levels;

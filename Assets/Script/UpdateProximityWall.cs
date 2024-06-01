using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateProximityWall : MonoBehaviour
{
    public Renderer[] walls;
    public Transform player;

    void Update()
    {
        if (walls.Length < 1) return;
        if (player == null) return;
        for (int i = 0; i < walls.Length; i++)
        {
            walls[i].material.SetVector("_PlayerPos", player.position);
        }       
    }
}

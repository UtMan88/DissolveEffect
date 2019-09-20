using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using DG.Tweening;

[ExecuteInEditMode]
public class DissolveEffect : MonoBehaviour
{
    public Material[] dissolveMaterials;
    public UnityEvent OnFadeIn;
    public UnityEvent OnFadeOut;

    [Range(0, 1)]
    public float SliceAmount = 0.0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        foreach(Material m in dissolveMaterials)
        {
            m.SetFloat("_SliceAmount", SliceAmount);
        }
    }

    public void FadeOut()
    {
        DOTween.To((x) => SliceAmount = x, SliceAmount, 1, 5f).OnComplete(() =>
        {
            if (OnFadeOut != null)
                OnFadeOut.Invoke();
        });
    }

    public void FadeIn()
    {
        DOTween.To((x) => SliceAmount = x, SliceAmount, 0, 5f).OnComplete(() =>
        {
            if (OnFadeIn != null)
                OnFadeIn.Invoke();
        });
    }

    public Tweener FadeOutFast()
    {
        return DOTween.To((x) => SliceAmount = x, SliceAmount, 1, 0.75f).OnComplete(() =>
        {
            if (OnFadeOut != null)
                OnFadeOut.Invoke();
        });
    }

    public Tweener FadeInFast()
    {
        return DOTween.To((x) => SliceAmount = x, SliceAmount, 0, 0.75f).OnComplete(() =>
        {
            if (OnFadeIn != null)
                OnFadeIn.Invoke();
        });
    }

}

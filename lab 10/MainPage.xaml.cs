
using System;
using Microsoft.Maui.Controls;

namespace MauiApp1;

public partial class MainPage : ContentPage
{
    public MainPage()
    {
        InitializeComponent();
    }

    // View Full Profile Button Event

    private async void OnProfileClicked(
        object sender, EventArgs e)
    {
        await DisplayAlert(
            "Student Profile",
            "Name: Rahul Sharma\n" +
            "Role: Software Developer\n" +
            "Posts: 120\n" +
            "Followers: 850\n" +
            "Following: 300",
            "OK");
    }
}

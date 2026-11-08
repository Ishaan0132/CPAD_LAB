using System;
using System.Collections.ObjectModel;
using Microsoft.Maui.Controls;

namespace MauiApp1;

public partial class MainPage : ContentPage
{
    int likeCount = 0;

    public ObservableCollection<string> Skills { get; set; }

    public MainPage()
    {
        InitializeComponent();

        Skills = new ObservableCollection<string>()
        {
            "C#",
            "Xamarin",
            ".NET",
            "Git",
            "SQL",
            "HTML"
        };

        BindingContext = this;
    }

    private void OnLikeClicked(object sender, EventArgs e)
    {
        likeCount++;
        likeButton.Text = $"Like ({likeCount})";
    }

    private async void OnMessageClicked(object sender, EventArgs e)
    {
        await DisplayAlert(
            "Message",
            "Message button clicked successfully!",
            "OK");
    }

    private async void OnPostCommentClicked(object sender, EventArgs e)
    {
        string comment = commentEntry.Text;

        if (!string.IsNullOrWhiteSpace(comment))
        {
            commentResult.Text = "Comment: " + comment;
            commentEntry.Text = "";

            await DisplayAlert(
                "Success",
                "Comment posted successfully!",
                "OK");
        }
        else
        {
            await DisplayAlert(
                "Warning",
                "Please enter a comment.",
                "OK");
        }
    }
}

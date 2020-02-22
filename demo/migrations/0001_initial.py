# Generated by Django 2.2.10 on 2020-02-17 07:33

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="Book",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(max_length=255)),
                ("archived", models.BooleanField(default=False)),
                ("amount", models.DecimalField(decimal_places=2, max_digits=9)),
                (
                    "amount_off",
                    models.DecimalField(
                        blank=True, decimal_places=2, max_digits=7, null=True
                    ),
                ),
                (
                    "percentage",
                    models.DecimalField(
                        blank=True, decimal_places=0, max_digits=3, null=True
                    ),
                ),
                (
                    "created_by",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
        migrations.CreateModel(
            name="Library",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(max_length=255)),
            ],
        ),
        migrations.CreateModel(
            name="LibraryBook",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "books",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.PROTECT, to="demo.Book"
                    ),
                ),
                (
                    "library",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="library_books",
                        to="demo.Library",
                    ),
                ),
            ],
        ),
        migrations.AddField(
            model_name="library",
            name="books",
            field=models.ManyToManyField(through="demo.LibraryBook", to="demo.Book"),
        ),
    ]

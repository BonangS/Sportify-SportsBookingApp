# Setting Up Supabase Storage for Profile Pictures

To fix the "StorageException: new row violates row-level security policy" error, follow these steps to properly configure your Supabase storage:

## 1. Create the "images" bucket in Supabase

1. Log in to your Supabase dashboard
2. Go to the "Storage" section in the left menu
3. Click on "New Bucket"
4. Enter "images" as the bucket name (exactly as it appears in your code)
5. Select "Public" bucket if you want the images to be publicly accessible
6. Click "Create Bucket"

## 2. Configure Row Level Security (RLS) Policy

After creating the bucket, you need to add a security policy to allow authenticated users to upload files:

1. Click on the "images" bucket you just created
2. Go to the "Policies" tab
3. Click "Add Policy" (or "New Policy")

### For Uploading Images Policy

Create a policy with the following settings:

- Policy Type: INSERT (allows file uploads)
- Policy Name: "Allow authenticated users to upload files"
- Policy Definition: Use the template below or adjust as needed

```sql
(auth.role() = 'authenticated')
```

### For Viewing/Reading Images Policy

Create another policy with these settings:

- Policy Type: SELECT (allows file viewing)
- Policy Name: "Allow public access to files"
- Policy Definition: For public access, use:

```sql
true
```

### For Additional Access (if needed)

You might also want to add UPDATE and DELETE policies if users need to modify or delete their profile pictures:

- Policy Type: UPDATE
- Policy Definition:

```sql
(auth.role() = 'authenticated' AND auth.uid() = owner)
```

- Policy Type: DELETE
- Policy Definition:

```sql
(auth.role() = 'authenticated' AND auth.uid() = owner)
```

## 3. Test Your App Again

After configuring these policies, restart your Flutter app and test the profile picture upload again. It should now work without security policy violations.

## Troubleshooting

If you're still experiencing issues:

1. Check that you're properly authenticated in your app before trying to upload
2. Verify the bucket name in your code matches exactly the one in Supabase (case-sensitive)
3. Look at the Supabase logs for more detailed error information
4. Try implementing a custom owner field if you want more granular permissions

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// 🔐 Configure the email account you're sending from
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: '<your-email@gmail.com>',       
    pass: '<your-email-password>',     
  },
});

// ✅ Send OTP to email
exports.sendOtp = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const otp = Math.floor(1000 + Math.random() * 9000).toString();

  // 🔐 Store OTP in Firestore
  await admin.firestore().collection('otp_verification').doc(email).set({
    otp: otp,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const mailOptions = {
    from: 'Explore Uganda <your-email@gmail.com>',
    to: email,
    subject: 'Your OTP Code',
    html: `<p>Your OTP code is <b>${otp}</b>. It expires in 5 minutes.</p>`,
  };

  await transporter.sendMail(mailOptions);
  return { success: true };
});

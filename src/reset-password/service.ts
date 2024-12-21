import { PrincipalIdentity, User } from '../types.js';
import { createToken } from '../verification-token/service.js';
import { BadRequest } from '@curveball/http-errors';
import { sendTemplatedMail } from '../mailer/service.js';

/**
 * This function is for sending reset password email with validated token
 *
 * This flow, it will first check if email and URL environment variable has been set.
 *
 * Renders an email with provided from, to, subject, html template.
 */
export async function sendResetPasswordEmail(user: User, identity: PrincipalIdentity) {

  const token = await createToken(user, null, identity);

  if (!identity.href.startsWith('mailto:')) {
    throw new BadRequest('You can only request a password reset with an email address.');
  }

  // send mail with defined transport object
  await sendTemplatedMail(
    {
      to: identity.href.substring(7), // list of receivers
      subject: 'Password reset request', // Subject line
      templateName: 'emails/reset-password-email',
    },
    {
      name: user.nickname,
      url: process.env.PUBLIC_URI + 'reset-password/token/' + token.token,
      expiryHours: token.ttl / 60 / 60
    }
  );


}
